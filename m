From: "=?iso-8859-1?q?R=E9mi?= Denis-Courmont"
	<remi.denis-courmont@nokia.com>
Subject: Re: [RFC 1/2] net: Introduce recvmmsg socket syscall
Date: Fri, 22 May 2009 10:22:48 +0300
Message-ID: <200905221022.48790.remi.denis-courmont@nokia.com>
References: <20090520230652.GB5956@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Chris Van Hoof <vanhoof@redhat.com>,
	Clark Williams <williams@redhat.com>
To: ext Arnaldo Carvalho de Melo <acme@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.122.233]:22083 "EHLO
	mgw-mx06.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751824AbZEVHWL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 May 2009 03:22:11 -0400
In-Reply-To: <20090520230652.GB5956@ghostprotocols.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 21 May 2009 02:06:52 ext Arnaldo Carvalho de Melo wrote:
> +       /*
> +        * We may return less entries than requested (vlen) if the
> +        * sock is non block and there aren't enough datagrams.
> +        */
> +       if (err =3D=3D 0 || (err =3D=3D -EAGAIN && (flags & MSG_DONTW=
AIT)))
> +               return datagrams;
>         return err;
>  }

Could there be a situation whereby we receive one or more datagrams, th=
en get=20
an error? How does userland get the datagrams then?

--=20
R=E9mi Denis-Courmont
Nokia Devices R&D, Maemo Software, Helsinki

