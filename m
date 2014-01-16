From: Michael Dalton <mwdalton@google.com>
Subject: Re: [PATCH net-next v3 4/5] net-sysfs: add support for
	device-specific rx queue sysfs attributes
Date: Thu, 16 Jan 2014 11:07:36 -0800
Message-ID: <CANJ5vP+nDgi7vWOd=RSuZ=NS5Z_txEkEsoYYm_33sFPh6rr=gg@mail.gmail.com>
References: <1389865126-26225-1-git-send-email-mwdalton@google.com>
	<1389865126-26225-4-git-send-email-mwdalton@google.com>
	<1389898650.11912.65.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org,
	lf-virt <virtualization@lists.linux-foundation.org>,
	Eric Dumazet <edumazet@google.com>, "David S. Miller" <davem@davemloft.net>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1389898650.11912.65.camel@bwh-desktop.uk.level5networks.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Jan 16, 2014 at 10:57 AM, Ben Hutchings <bhutchings@solarflare.com> wrote:
> Why write a loop when you can do:
>         i = queue - dev->_rx;
Good point, the loop approach was done in get_netdev_queue_index --
I agree your fix is faster and simpler. I'll fix in next patchset.
Thanks!

Best,

Mike
