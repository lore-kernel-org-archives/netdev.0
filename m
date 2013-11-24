From: Shawn Landden <shawnlandden@gmail.com>
Subject: AF_ALG does not work with sendfile()
Date: Sun, 24 Nov 2013 09:12:18 -0800
Message-ID: <CAJusiZW1U93-wS0kPkSQprj+BzXVz29078mCaQ8zt39AB0gvuQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, linux-crypto@vget.kernel.org,
	herbert@gondor.apana.org.au
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If I use sendfile() to send to a accept()ed AF_ALG socket set up for
"hash", I get the wrong
answer, if I read() and then write() I get the right answer. None of
the system calls return an error.
---
Shawn Landden
+1 360 389 3001 (SMS preferred)
