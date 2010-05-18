From: Avi Kivity <avi@redhat.com>
Subject: Re: [PATCHv2] vhost-net: utilize PUBLISH_USED_IDX feature
Date: Tue, 18 May 2010 20:47:19 +0300
Message-ID: <4BF2D2A7.8030803@redhat.com>
References: <20100518022105.GA23129@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, Juan Quintela <quintela@redhat.com>,
	Rusty Russell <rusty@rustcorp.com.au>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Arnd Bergmann <arnd@arndb.de>, kvm@vger.kernel.org,
	virtualization@lists.osdl.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, alex.williamson@redhat.com,
	amit.shah@redhat.com
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100518022105.GA23129@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/18/2010 05:21 AM, Michael S. Tsirkin wrote:
> With PUBLISH_USED_IDX, guest tells us which used entries
> it has consumed. This can be used to reduce the number
> of interrupts: after we write a used entry, if the guest has not yet
> consumed the previous entry, or if the guest has already consumed the
> new entry, we do not need to interrupt.
> This imporves bandwidth by 30% under some workflows.
>    

Seems to be missing the cacheline alignment.

Rusty's clarification did not satisfy me, I think it's needed.

-- 
I have a truly marvellous patch that fixes the bug which this
signature is too narrow to contain.
