From: Joseph Salisbury <joseph.salisbury@canonical.com>
Subject: [PATCH][v3.19.y] tun: return proper error code from tun_do_read
Date: Tue, 28 Apr 2015 16:27:31 -0400
Message-ID: <553FED33.8020406@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: agartrell@fb.com, "davem@davemloft.net" <davem@davemloft.net>,
	mst@redhat.com, jasowang@redhat.com, herbert@gondor.apana.org.au,
	viro@zeniv.linux.org.uk, Ben Hutchings <ben@decadent.org.uk>,
	xii@google.com, vyasevich@gmail.com,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	"stable@vger.kernel.org" <stable@vger.kernel.org>
To: Greg KH <gregkh@linuxfoundation.org>
Return-path: <stable-owner@vger.kernel.org>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

Please consider including mainline commit
957f094f221f81e457133b1f4c4d95ffa49ff731 in the next v3.19.y release. 
It was included in the mainline tree as of v4.0-rc1.  It has been tested
and confirmed to resolve:
http://bugs.launchpad.net/bugs/1448942
And upstream bug report:
https://bugzilla.kernel.org/show_bug.cgi?id=90901

The bug was introduce in v3.19-rc1 by commit 9b067034d0, so it is not
needed in any other stable kernels.



commit 957f094f221f81e457133b1f4c4d95ffa49ff731
Author: Alex Gartrell <agartrell@fb.com>
Date:   Thu Dec 25 23:22:49 2014 -0800

    tun: return proper error code from tun_do_read



Sincerely,

Joseph Salisbury
