From: "=?iso-8859-15?q?R=E9mi?= Denis-Courmont" <remi@remlab.net>
Subject: Re: [PATCH] phonet: Check input from user before allocating
Date: Mon, 2 Apr 2012 22:01:40 +0300
Message-ID: <201204022201.41808.remi@remlab.net>
References: <1333398660-11552-1-git-send-email-levinsasha928@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: remi.denis-courmont@nokia.com, davem@davemloft.net,
	davej@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Sasha Levin <levinsasha928@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1333398660-11552-1-git-send-email-levinsasha928@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le lundi 2 avril 2012 23:31:00 Sasha Levin, vous avez =E9crit :
> A phonet packet is limited to USHRT_MAX bytes, this is never checked =
during
> tx which means that the user can specify any size he wishes, and the =
kernel
> will attempt to allocate that size.

Does this really solve the problem?  I guess 128kb is still possible wi=
th=20
USHRT_MAX plus skbuff overhead, which might still trigger OOM relativel=
y=20
easily once the memory gets sufficiently fragmented.

How does UDP deal with this?

--=20
R=E9mi Denis-Courmont
http://www.remlab.net/
http://fi.linkedin.com/in/remidenis
