From: "=?iso-8859-1?q?R=E9mi?= Denis-Courmont"
	<remi.denis-courmont@nokia.com>
Subject: Re: [Resent][PATCH 1/2] inet6: Conversion from u8 to int
Date: Mon, 10 Aug 2009 09:33:10 +0300
Message-ID: <200908100933.11676.remi.denis-courmont@nokia.com>
References: <resolve_IPV6_TCLASS> <1249841569-23706-1-git-send-email-gerrit@erg.abdn.ac.uk> <1249841569-23706-2-git-send-email-gerrit@erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: ext Gerrit Renker <gerrit@erg.abdn.ac.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.105.134]:53906 "EHLO
	mgw-mx09.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750875AbZHJGdW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Aug 2009 02:33:22 -0400
In-Reply-To: <1249841569-23706-2-git-send-email-gerrit@erg.abdn.ac.uk>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sunday 09 August 2009 21:12:48 ext Gerrit Renker wrote:
>  	case IPV6_TCLASS:
>  		val =3D np->tclass;
> -		if (val < 0)
> -			val =3D 0;
>  		break;

According to the IPv6 API RFC, if val is -1, the kernel shall pick the =
default=20
value (which is zero). Are you sure this still works??

--=20
R=E9mi Denis-Courmont
Nokia Devices R&D, Maemo Software, Helsinki

