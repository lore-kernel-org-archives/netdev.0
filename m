From: =?ISO-8859-1?Q?Fran=E7ois_Cachereul?= <f.cachereul@alphalink.fr>
Subject: Re: [RFC PATCH net-next] ppp: Allow ppp device connected to an l2tp
 session to change of namespace
Date: Fri, 25 Oct 2013 10:24:12 +0200
Message-ID: <526A2AAC.4060809@alphalink.fr>
References: <5268F6CD.9070600@alphalink.fr> <5268FCB1.7020903@katalix.com> <526923A7.8090108@alphalink.fr> <5269402E.2070203@katalix.com> <20131024155354.GQ2704@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: James Chapman <jchapman@katalix.com>,
	Paul Mackerras <paulus@samba.org>, netdev@vger.kernel.org,
	linux-ppp@vger.kernel.org
To: Benjamin LaHaise <bcrl@kvack.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:46827 "EHLO
	mail-2-cbv2.admin.alphalink.fr" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752392Ab3JYIYO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Oct 2013 04:24:14 -0400
In-Reply-To: <20131024155354.GQ2704@kvack.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/24/2013 05:53 PM, Benjamin LaHaise wrote:
> On Thu, Oct 24, 2013 at 04:43:42PM +0100, James Chapman wrote:
>> I'm thinking about the implications of a skb in the net namespace of=
 the
>> ppp interface passing through a tunnel socket which is in another
>> namespace. I think net namespaces are completely isolated.
>>
>> To keep your ppp interfaces isolated from each other, have you
>> considered using netfilter to prevent data being passed between ppp
>> interfaces?
>=20
> Using network namespaces for this is far more efficient.  We've alrea=
dy=20
> added support for doing this to other tunneling interfaces.  This app=
roach=20
> also makes creating VPNs where there is re-use of the private address=
 space=20
> between different customers far easier to implement.
>=20
> 		-ben

That's indeed on of the problems we have to deal with and net namespace=
s
seems to be the right answer.

=46ran=E7ois
