From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [RFC 4/4] net: ppp_generic - introduce net-namespace
	functionality
Date: Sun, 11 Jan 2009 10:46:52 +0300
Message-ID: <20090111074652.GB7686@localhost>
References: <20090109195154.320495476@gmail.com> <4967accd.0305560a.3553.ffffd187@mx.google.com> <20090110092258.GA7622@localhost> <20090110092830.GB7622@localhost> <18793.15953.591733.958862@cargo.ozlabs.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, devel@openvz.org, xemul@openvz.org
To: Paul Mackerras <paulus@samba.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.158]:57266 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751131AbZAKHq4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Jan 2009 02:46:56 -0500
Content-Disposition: inline
In-Reply-To: <18793.15953.591733.958862@cargo.ozlabs.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[Paul Mackerras - Sun, Jan 11, 2009 at 11:33:21AM +1100]
| Cyrill Gorcunov writes:
| 
| > From: Cyrill Gorcunov <gorcunov@gmail.com>
| > Subecjt: [RFC] net: ppp_generic - introduce net-namespace functionality
| > 
| > - Each namespace contain ppp channels and units separately
| >   with appropriate locks
| 
| This looks like a lot of uglification to me.  Why exactly do
| individual network drivers need to know or care about namespaces?
| 
| Paul.
| 

Unfortunately in the whole series ppp has been change more
then others and it's looks ugly indeed that is why it was RFC.
Namespaces imply isolation of data right? Including private
data being 'user related' -- ie units passed to user in one
namespace should not interfere with units passed to user in
another namespace. So if I will not 'bind' units pool to
namespaces it would be possible to steal unit from one namespace
proposed for another namespace. Right?

		- Cyrill -
