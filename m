From: Patrick McHardy <kaber@trash.net>
Subject: Re: [Drbd-dev] [PATCH 2/2 v2] netlink: kill eff_cap from struct netlink_skb_parms
Date: Tue, 08 Mar 2011 15:50:47 +0100
Message-ID: <4D764247.9080509@trash.net>
References: <4D6F6180.5030903@trash.net> <20110303173230.GP4988@sequoia.sous-sol.org> <20110303.105655.189705829.davem@davemloft.net> <20110303201522.GT4988@sequoia.sous-sol.org> <20110303223746.GI25069@barkeeper1-xen.linbit> <20110304012956.GA13573@ioremap.net>
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
In-Reply-To: <20110304012956.GA13573@ioremap.net>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am 04.03.2011 02:29, schrieb Evgeniy Polyakov:
> Hi.
> 
> On Thu, Mar 03, 2011 at 11:37:46PM +0100, Lars Ellenberg (lars.ellenberg@linbit.com) wrote:
>> If so, then this change introduces the possibility for normal users to
>> send privileged commands to connector based subsystems, even if they
>> may not be able to bind() to suitable sockets to receive any replies.
>>
>> Am I missing something?
> 
> Yup, connector is very async at that place, but I wonder why the hell I
> ever made that decision. I believe we can replace it with pure sync call
> of the registered connector callback, since netlink is synchronous and
> no one has any problem with it.
> 

Are you going to do this or do you want me to take care of it?
