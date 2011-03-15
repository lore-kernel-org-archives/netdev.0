From: Alexander Zimmermann <alexander.zimmermann@comsys.rwth-aachen.de>
Subject: Re: [PATCH] tcp: avoid cwnd moderation in undo
Date: Tue, 15 Mar 2011 19:50:51 +0100
Message-ID: <D7A3999B-4112-4B95-A36B-1F22FC44FD56@comsys.rwth-aachen.de>
References: <1299894051-13820-1-git-send-email-ycheng@google.com>
 <AANLkTimra1e-ONMx2hTeN90HFEvxqb3jPAr4v9_C+9wR@mail.gmail.com>
 <AANLkTi=qi2GOprXEWCf6v=j=L98SQMdHb1OaHcdALepf@mail.gmail.com>
 <201103151120.55388.carsten@wolffcarsten.de>
 <AANLkTim_U9CySFQimQ8cG_iHdXCYXSALi9E6ticKztnk@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7BIT
Cc: Carsten Wolff <carsten@wolffcarsten.de>,
	Yuchung Cheng <ycheng@google.com>,
	David Miller <davem@davemloft.net>,
	Ilpo Jarvinen <ilpo.jarvinen@helsinki.fi>,
	Nandita Dukkipati <nanditad@google.com>, netdev@vger.kernel.org
To: John Heffner <johnwheffner@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta-1.ms.rz.RWTH-Aachen.DE ([134.130.7.72]:55341 "EHLO
	mta-1.ms.rz.rwth-aachen.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758353Ab1COTUz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Mar 2011 15:20:55 -0400
Received: from ironport-out-2.rz.rwth-aachen.de ([134.130.5.41])
 by mta-1.ms.rz.RWTH-Aachen.de
 (Sun Java(tm) System Messaging Server 6.3-7.04 (built Sep 26 2008))
 with ESMTP id <0LI4001D94CTSZA0@mta-1.ms.rz.RWTH-Aachen.de> for
 netdev@vger.kernel.org; Tue, 15 Mar 2011 19:50:53 +0100 (CET)
Received: from [192.168.4.14] ([unknown] [77.109.98.124])
 by relay-auth-2.ms.rz.rwth-aachen.de
 (Sun Java(tm) System Messaging Server 7.0-3.01 64bit (built Dec  9 2008))
 with ESMTPA id <0LI400LK14CTTL30@relay-auth-2.ms.rz.rwth-aachen.de> for
 netdev@vger.kernel.org; Tue, 15 Mar 2011 19:50:53 +0100 (CET)
In-reply-to: <AANLkTim_U9CySFQimQ8cG_iHdXCYXSALi9E6ticKztnk@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Hi John,

Am 15.03.2011 um 11:50 schrieb John Heffner:

> 
> While I'm adding to my wish list ;-), I will also say that the undo
> logic seems unnecessarily complicated.  If you expect you might have
> to undo what you just did, why not wait a bit?  Something like rfc4653
> seems like it might be a better approach and might make the cwnd
> moderation discussion moot.
> 

actually, our group (including Carsten) implemented RFC4653 for Linux.
At the moment, we run our final measurements. However, since I leave
the university, the work is not making much progress. Nevertheless I
I hope that we can finish this in the next couple of months. Besides the
Linux patch, we will bring an rfc4653bis as well as a reordering detection
draft to tcpm.

Alex 


//
// Dipl.-Inform. Alexander Zimmermann
// Department of Computer Science, Informatik 4
// RWTH Aachen University
// Ahornstr. 55, 52056 Aachen, Germany
// phone: (49-241) 80-21422, fax: (49-241) 80-22222
// email: zimmermann@cs.rwth-aachen.de
// web: http://www.umic-mesh.net
//

-----BEGIN PGP SIGNATURE-----
Version: GnuPG/MacGPG2 v2.0.17 (Darwin)
Comment: GPGTools - http://gpgtools.org

iEYEARECAAYFAk1/tQsACgkQdyiq39b9uS7cFACeLaNsGVWoiVzAnUjXOnz8Y/Lk
fp0An0IlprotGMbtl1nXC62oyVEHcHv1
=zxT9
-----END PGP SIGNATURE-----
