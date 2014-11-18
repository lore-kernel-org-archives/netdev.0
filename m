From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH net-next 1/4] net: allow large number of rx queues
Date: Tue, 18 Nov 2014 12:29:15 -0800
Message-ID: <CAHA+R7MnLy=8uL_hSnx=BN2QTs2kvempTxtmSO6hjcS+E0yRwg@mail.gmail.com>
References: <1416327778-17716-1-git-send-email-pagupta@redhat.com>
	<1416327778-17716-2-git-send-email-pagupta@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Jason Wang <jasowang@redhat.com>,
	"Michael S. Tsirkin" <mst@redhat.com>, dgibson@redhat.com,
	vfalico@gmail.com, Eric Dumazet <edumazet@google.com>,
	Vladislav Yasevich <vyasevic@redhat.com>,
	Jerry Chu <hkchu@google.com>,
	wuzhy@linux.vnet.ibm.com.pnq.redhat.com,
	Pavel Emelyanov <xemul@parallels.com>,
	Tom Herbert <therbert@google.com>, bhutchings@solarflare.com,
	xii@google.com, Stephen Hemminger <stephen@networkplumber.org>,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	sergei.shtylyov@cogentembedded.com
To: Pankaj Gupta <pagupta@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1416327778-17716-2-git-send-email-pagupta@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 18, 2014 at 8:22 AM, Pankaj Gupta <pagupta@redhat.com> wrote:
>
> As vmalloc() adds overhead on a critical network path,
> __GFP_REPEAT flag is used with kzalloc() to do this fallback
> only when really needed.
>

Are you sure we need __GFP_REPEAT? We have vmalloc() as
fallback of kmalloc() in many places of networking (grep kvfree),
none of those I checked has this flag set.
