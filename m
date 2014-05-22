From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: Bonding with tun-devices
Date: Thu, 22 May 2014 17:00:25 +0200
Message-ID: <20140522150025.GE6295@redhat.com>
References: <537CB13A.3030100@markas-al-nour.org>
 <20140521155434.GC6295@redhat.com>
 <537D0E52.9030901@markas-al-nour.org>
 <20140522132436.GD6295@redhat.com>
 <537E0E9D.8060405@markas-al-nour.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Linus Gasser <list@markas-al-nour.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59697 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750756AbaEVPAw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 May 2014 11:00:52 -0400
Content-Disposition: inline
In-Reply-To: <537E0E9D.8060405@markas-al-nour.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 22, 2014 at 03:50:05PM +0100, Linus Gasser wrote:
>Le 22/05/14 14:24, Veaceslav Falico a =E9crit :
>>A workaround would be to use tap devices, as they're more "real" and
>>support mac address setting.
>
>OK, what can I say - thank you for helping me not to have fiddled=20
>around with it more than needed ;) If you manage to support=20
>non-mac-connections, this would be great, of course. Else I'll have=20
>to try Openvpn which supports tap-devices.

Quick googling says that ssh -o Tunnel=3Dethernet creates a tap device,=
 so no
need for openvpn. Disclaimer - I've never actually tried it, so dunno i=
f
it'll work.

I'll add you on CC once the patch supporting tun is sent.

Hope that helps.

>
>Thanks for your efforts
