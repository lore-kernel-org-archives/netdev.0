From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] macvlan: validate flags
Date: Thu, 1 Aug 2013 17:45:28 +0300
Message-ID: <20130801144528.GA16896@redhat.com>
References: <1375353992-7181-1-git-send-email-mst@redhat.com>
 <51FA7255.1070102@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Roopa Prabhu <roprabhu@cisco.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <51FA7255.1070102@cogentembedded.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 01, 2013 at 06:36:05PM +0400, Sergei Shtylyov wrote:
> Hello.
> 
> On 01-08-2013 14:48, Michael S. Tsirkin wrote:
> 
> >commit df8ef8f3aaa6692970a436204c4429210addb23a
> 
>    Please also specify that commit's summary line in parens.
> This is the only way to uniquely identify the commit, and it's the
> requirement that came originally from Linus AFAIK.

Ouch, no idea why do I keep making this mistake.
Will do, thanks.

> >added a flags field to macvlan, which can be
> >controlled from userspace.
> >The idea is to make the interface future-proof
> >so we can add flags and not new fields.
> 
> >However, flags value isn't validated, as a result,
> >userspace can't detect which flags are supported.
> 
> >Cc: "David S. Miller" <davem@davemloft.net>
> >CC: Roopa Prabhu <roprabhu@cisco.com>
> >Cc: John Fastabend <john.r.fastabend@intel.com>
> >Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> 
> WBR, Sergei
