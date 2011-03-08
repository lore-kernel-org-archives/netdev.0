From: Patrick McHardy <kaber@trash.net>
Subject: Re: [Drbd-dev] [PATCH 2/2 v2] netlink: kill eff_cap from struct netlink_skb_parms
Date: Tue, 08 Mar 2011 19:54:33 +0100
Message-ID: <4D767B69.2030603@trash.net>
References: <4D6F6180.5030903@trash.net> <20110303173230.GP4988@sequoia.sous-sol.org> <20110303.105655.189705829.davem@davemloft.net> <20110303201522.GT4988@sequoia.sous-sol.org> <20110303223746.GI25069@barkeeper1-xen.linbit> <20110304012956.GA13573@ioremap.net> <4D764247.9080509@trash.net> <20110308183246.GA17412@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Chris Wright <chrisw@sous-sol.org>,
	David Miller <davem@davemloft.net>,
	linux-fbdev@vger.kernel.org, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org, dm-devel@redhat.com,
	drbd-dev@lists.linbit.com
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20110308183246.GA17412@ioremap.net>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am 08.03.2011 19:32, schrieb Evgeniy Polyakov:
> Hi Patrick.
> 
> On Tue, Mar 08, 2011 at 03:50:47PM +0100, Patrick McHardy (kaber@trash.net) wrote:
>>> Yup, connector is very async at that place, but I wonder why the hell I
>>> ever made that decision. I believe we can replace it with pure sync call
>>> of the registered connector callback, since netlink is synchronous and
>>> no one has any problem with it.
>>
>> Are you going to do this or do you want me to take care of it?
> 
> I will return back at the end of the week and will take care of this
> problem. I will not mind if you complete it first though :)

Thanks Evgeniy, I'll give it a shot.
