From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 1/2] libceph: Remove unneeded stddef.h include
Date: Mon, 6 Feb 2017 16:16:55 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DB027CAAA@AcuExch.aculab.com>
References: <cover.1486276931.git.shorne@gmail.com>
 <b49a86823ae528ff795c8931f68392535b0fccf7.1486276931.git.shorne@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: Ilya Dryomov <idryomov@gmail.com>, "Yan, Zheng" <zyan@redhat.com>,
        "Sage Weil" <sage@redhat.com>,
        "David S. Miller" <davem@davemloft.net>,
        "ceph-devel@vger.kernel.org" <ceph-devel@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: 'Stafford Horne' <shorne@gmail.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <b49a86823ae528ff795c8931f68392535b0fccf7.1486276931.git.shorne@gmail.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stafford Horne
> Sent: 05 February 2017 07:08
> This was causing a build failure for openrisc when using musl and
> gcc 5.4.0 since the file is not available in the toolchain.
> 
> It doesnt seem this is needed and removing it does not cause any build
> warnings for me.

Hmmm... stddef.h is part of the SuS v2.
Required to get definitions for NULL, offsetof(), ptrdiff_t and size_t.

So any system that is pretending to by unix-like ought to have one.

	David
