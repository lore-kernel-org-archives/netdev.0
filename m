From: jamal <hadi@cyberus.ca>
Subject: Re: [Bugme-new] [Bug 14837] New: gretap does not fragment IP
 packets
Date: Mon, 21 Dec 2009 14:09:03 -0500
Message-ID: <1261422543.8201.6.camel@bigi>
References: <bug-14837-10286@http.bugzilla.kernel.org/>
	 <20091218153209.45042a58.akpm@linux-foundation.org>
	 <1261227303.11973.2.camel@bigi>  <4B2ECCAB.8010702@free.fr>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: Benoit PAPILLAULT <benoit.papillault@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f187.google.com ([209.85.210.187]:54063 "EHLO
	mail-yx0-f187.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757056AbZLUTJH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Dec 2009 14:09:07 -0500
Received: by yxe17 with SMTP id 17so5144758yxe.33
        for <netdev@vger.kernel.org>; Mon, 21 Dec 2009 11:09:06 -0800 (PST)
In-Reply-To: <4B2ECCAB.8010702@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2009-12-21 at 02:17 +0100, Benoit PAPILLAULT wrote:

> >   
> As I explained in my original message, the gre device MTU must be 1500 
> bytes (since it is used in an Ethernet bridge). 

Ok, sorry i missed this bit. I didnt realize that the bridge device had
such draconian enforcement. Bridge picks whatever the lowest common
denominator is for MTU (I suspect so as to not keep track of all the
interfaces; good policy, IMO, should allow a user to shoot themselves in
the toe while defaulting to the min mtu).
>From the looks of it, this enforcement could be changed with a one line
patch - but not being privy to the reasoning it would be unfair of me to
do so from my comfortable couch. Stephen?

> To reproduce the 
> problem, I did a very simple setup with two machines (A & B) connected 
> with an Ethernet cable (so no router between them).
> 
> On machine A :
> # ip link add gre0 type gretap local <A> remote <B>
> # ifconfig gre0 mtu 1500

What i meant is try to ifconfig gre0 to something small like 1420B

cheers,
jamal

