From: "Rose, Gregory V" <gregory.v.rose@intel.com>
Subject: ip addr add command generates error
Date: Mon, 23 Mar 2015 22:43:00 +0000
Message-ID: <C5551D9AAB213A418B7FD5E4A6F30A0789291C3A@ORSMSX108.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: "stephen.hemminger@vyatta.com" <stephen.hemminger@vyatta.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"vadim4j@gmail.com" <vadim4j@gmail.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:14984 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752214AbbCWWnH convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2015 18:43:07 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The 'ip addr add' command used to use the following syntax:

# ip addr add 10.0.0.2/24 brd 10.0.0.255 dev <eth>

However, attempts to use that same command syntax with the current ipro=
ute2 tip gives the following error:

Error: an inet prefix is expected rather than "20.0.0.2/24"

This seems like a bug.  The commit that introduces the issue is f3a2ddc=
124e09d3990b836e322ed39c76c35546e by Vadim Kochan.  Reverting this comm=
it fixes the problem.

Is this change deliberate?  It would break a lot of scripts if so.

Thanks,

- Greg

----------
=A0
Any man who afflicts the human race with ideas must be prepared to see =
them misunderstood.
=A0
- H. L. Mencken
