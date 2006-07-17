From: Erik Mouw <erik@harddisk-recovery.com>
Subject: Re: dscape git
Date: Mon, 17 Jul 2006 16:57:17 +0200
Message-ID: <20060717145717.GG14430@harddisk-recovery.com>
References: <20060717141503.85270.qmail@web60721.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dtp.xs4all.nl ([80.126.206.180]:51289 "HELO abra2.bitwizard.nl")
	by vger.kernel.org with SMTP id S1750820AbWGQO5T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Jul 2006 10:57:19 -0400
To: Tomas Winkler <tomas_bw@yahoo.com>
Content-Disposition: inline
In-Reply-To: <20060717141503.85270.qmail@web60721.mail.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 17, 2006 at 07:15:03AM -0700, Tomas Winkler wrote:
> I've tried to clone dscape git and I got the error
> bellow. I hade no problem go get other trees. I'm new
> to git so maybe I didn't use correct switches
> Command Line: git clone
> http://www.kernel.org/pub/scm/linux/kernel/git/jbenc/dscap
> e.git/ dscape

When available, use the git protocol. It's both faster and more
efficient.

> Thanks for help
> 
> got 0cdcef84239e5f1d60310883688b7aeca5278875
> error: The requested file was not found (curl_result =
> 22, http_code = 503, sha1
>  = 27fd37621255799602d74e94d670ff7a1658d40a)
> Getting pack list for
> http://www.kernel.org/pub/scm/linux/kernel/git/jbenc/dscap
> e.git/
> got 80f18b79eacc07319afe473023a5358cfbc11ae6
> Getting pack list for http://www.kernel.or
> error: The requested file was not found
> error: Unable to find
> 27fd37621255799602d74e94d670ff7a1658d40a under
> http://www.
> kernel.org/pub/scm/linux/kernel/git/jbenc/dscape.git/
> Cannot obtain needed blob
> 27fd37621255799602d74e94d670ff7a1658d40a
> while processing commit a495f8ec7590d6df5edc36bff419f25b8c3440de.

Could be that www.kernel.org didn't yet fully sync up with
master.kernel.org. Just wait, it usually gets corrected in half an
hour.

I just succesfully clone'd dscape with the following command line:

git clone --reference linux-2.6 \
  git://git.kernel.org/pub/scm/linux/kernel/git/jbenc/dscape.git dscape

The "--reference" parameter tells git that I have a local repository
called "linux-2.6" (which just follow Linus' 2.6 tree) which can be
used to pull the shared git objects from. Saves quite some disk space.


Erik

-- 
+-- Erik Mouw -- www.harddisk-recovery.com -- +31 70 370 12 90 --
| Lab address: Delftechpark 26, 2628 XH, Delft, The Netherlands
