From: jamal <hadi@cyberus.ca>
Subject: Re: Announce: NetKeeper Firewall For Linux
Date: 17 Nov 2003 09:21:58 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1069076627.1075.15.camel@jzny.localdomain>
References: <1067285612.552.9.camel@aphrodite.olympus.net>
	 <20031028014223.129933be.davem@redhat.com>
	 <1067335655.10628.7.camel@rade7.s.cs.auc.dk>
	 <1068001237.1064.31.camel@jzny.localdomain>
	 <1068046114.31636.92.camel@rade7.s.cs.auc.dk>
	 <1068089345.1020.17.camel@jzny.localdomain>
	 <1068114376.1532.115.camel@rade7.s.cs.auc.dk>
	 <1068211670.1031.49.camel@jzny.localdomain>  <3FAE9B9B.60007@cs.auc.dk>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Emmanuel Fleury <fleury@cs.auc.dk>, "David S. Miller" <davem@redhat.com>,
        netfilter-devel@lists.netfilter.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Mikkel Christiansen <mixxel@cs.auc.dk>
In-Reply-To: <3FAE9B9B.60007@cs.auc.dk>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

On Sun, 2003-11-09 at 14:55, Mikkel Christiansen wrote:

> >
> Integrate your classifer like any other tc
> >classifier and then you dont have to look at my code unless you really
> >want to.  
> >
> 
> If we integrate it would mean a new/alternative interface
> to tc where you compile the filter/configuratoin before
> uploading.

Why cant you use the same interface that exists today - the one that is
used to load new filter rules?

>  We believe this is a good thing since it allows
> admins to (syntax) check the filter before inserting it.

Sure. It will be nice to have something like that in user space.

> I believe the guys from shorewall sees this as a missing
> feature of iptables.
> 
> Would you consider such an interface for tc good are bad?
> 

Refer to my comment above: I dont think you need anything new. Look at a
simple classifier like fwmark and comment if you need something new.

> >Isnt the state database another classifier and therefore you will be
> >faced with the same challenges for it? 
> >I dont think you wuill get a free ride putting the state lookups
> >somewhere else.
> >
> current scheme cant handle dynamic rules - and it will
> be a while (if ever) before it can.
> 

Please think about that problem - otherwise you get an C in your course
work from me ;-> (F would be too harsh ;->)

> >
> >Couldnt you, knowing the rules already existing check for breakage in
> >user space?
> >
> no - if someone decided to write their own "client/compiler" in
> userspace they could potentially produce a broken IDD - that
> could crash the kernel!
> 

I think it is nice to have a feature that does the verification in
user space before downloading.  
I didnt understand what you mean that someone else writes their own
"client/compiler". Arent you the one in charge of this compiler?
Why would you allow other people to write this compiler?

cheers,
jamal
