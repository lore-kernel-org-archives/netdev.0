From: Paul Moore <paul.moore@hp.com>
Subject: [RFC PATCH 0/2] Labeled networking tweaks for 2.6.26
Date: Mon, 07 Apr 2008 19:16:23 -0400
Message-ID: <20080407231143.8087.77531.stgit@flek.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: linux-security-module@vger.kernel.org, netdev@vger.kernel.org,
	selinux@tycho.nsa.gov
Return-path: <linux-security-module-owner@vger.kernel.org>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pretty small pile of patches (are two patches even a pile) this time around,
but they should make things a little faster.  The first patch addresses a
gripe Casey had about an extra allocation/copy for the NetLabel secattr and
the second tries to address the Labeled IPsec stack ugliness pointed out by
Jamal and Dave.

I'm posting these as RFC patches for right now because I haven't had a chance
to really beat on these changes, however, with 2.6.26 getting close I wanted
to get these out so people could start looking at them.  Casey, Jamal, would
you mind checking these changes out in your respective configurations?

Thanks.

-- 
paul moore
linux security @ hp
