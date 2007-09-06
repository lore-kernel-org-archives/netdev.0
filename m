From: Mark Hindley <mark@hindley.org.uk>
Subject: Re: [PATCH -mm 1/2] 3c59x: Fix uninitialized variable bug
Date: Thu, 6 Sep 2007 22:40:08 +0100
Message-ID: <20070906214008.GA11224@hindley.org.uk>
References: <alpine.LFD.0.999.0709040340250.8504@enigma.security.iitk.ac.in> <20070904081602.GB4241@newton.mathematik.tu-chemnitz.de> <20070904085331.GH5944@hindley.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Steffen Klassert <klassert@mathematik.tu-chemnitz.de>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Linux Netdev Mailing List <netdev@vger.kernel.org>,
	Jeff Garzik <jeff@garzik.org>
To: Satyam Sharma <satyam@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 83-216-141-215.markhi700.adsl.metronet.co.uk ([83.216.141.215]:4303
	"EHLO mx.hindley.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932382AbXIFVkd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Sep 2007 17:40:33 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 06, 2007 at 03:25:55PM +0530, Satyam Sharma wrote:
 
> This is a GCC bug (regression, actually, as you've found out) -- no two
> ways about it. Although different from the kind Jeff mentioned couple days
> back -- that was about wising GCC up to false positives and /not/ emitting
> warnings. But here a genuine problem was not complained about, so this is
> more serious. Do you plan to open up a bug at gcc.gnu.org/bugzilla/ ?
> 

Yes, I have just narrowed down a test case, which is remarkably simple!

int 
main(int i)
{
  int err;
    
  if (i) {
    err = 1;
  }
  return err;
}

Mark
