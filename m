From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH v2] ptp: Allow selecting trigger/event index in testptp
Date: Tue, 4 Feb 2014 08:20:08 +0100
Message-ID: <20140204071239.GA6616@netboy>
References: <1391495106-4224-1-git-send-email-stefan.sorensen@spectralink.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Stefan =?iso-8859-1?Q?S=F8rensen?=
	<stefan.sorensen@spectralink.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f176.google.com ([209.85.215.176]:64189 "EHLO
	mail-ea0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751989AbaBDHUN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Feb 2014 02:20:13 -0500
Received: by mail-ea0-f176.google.com with SMTP id h14so4097679eaj.21
        for <netdev@vger.kernel.org>; Mon, 03 Feb 2014 23:20:12 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1391495106-4224-1-git-send-email-stefan.sorensen@spectralink.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sorry to be so picky, but...

On Tue, Feb 04, 2014 at 07:25:06AM +0100, Stefan S=F8rensen wrote:
> -	while (EOF !=3D (c =3D getopt(argc, argv, "a:A:cd:e:f:ghk:p:P:sSt:v=
"))) {
> +	while (EOF !=3D (c =3D getopt(argc, argv, "a:A:cd:e:f:ghk:p:P:sSt:v=
i:"))) {

how about keeping alphabetical order here

>  		switch (c) {
>  		case 'a':
>  			oneshot =3D atoi(optarg);
> @@ -209,6 +211,9 @@ int main(int argc, char *argv[])
>  		case 't':
>  			adjtime =3D atoi(optarg);
>  			break;
> +		case 'i':
> +			index =3D atoi(optarg);
> +			break;

and here?

>  		case 'h':
>  			usage(progname);
>  			return 0;

[ Yes, the 'h' is out of order.
  Pleae fix that, too, if you want to. ]

Thanks,
Richard
