From: Venkat Yekkirala <vyekkirala@trustedcs.com>
Subject: Multiple end-points behind same NAT
Date: Fri, 01 Dec 2006 14:32:17 -0600
Message-ID: <45709151.6060803@trustedcs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: dgoeddel@trustedcs.com, chanson@trustedcs.com, bphan@trustedcs.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from tcsfw4.tcs-sec.com ([65.127.223.133]:13477 "EHLO
	tcsfw4.tcs-sec.com") by vger.kernel.org with ESMTP id S936550AbWLAUc2
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Dec 2006 15:32:28 -0500
Received: (from smmsp@localhost)
	by tcsfw4.tcs-sec.com (8.12.2/8.12.2) id kB1KWRF0029790
	for <netdev@vger.kernel.org>; Fri, 1 Dec 2006 15:32:27 -0500 (EST)
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I am wondering if 26sec supports NAT-Traversal for multiple
endpoints behind the same NAT. In looking at xfrm_tmpl it's
not obvious to me that it's supported, at least going by the
following from the setkey man page:

             When NAT-T is enabled in the kernel, policy matching for ESP over
             UDP packets may be done on endpoint addresses and port (this
             depends on the system.  System that do not perform the port check
             cannot support multiple endpoints behind the same NAT).  When
             using ESP over UDP, you can specify port numbers in the endpoint
             addresses to get the correct matching.  Here is an example:

             spdadd 10.0.11.0/24[any] 10.0.11.33/32[any] any -P out ipsec
                 esp/tunnel/192.168.0.1[4500]-192.168.1.2[30000]/require ;

Or is this to be accomplished in a different way?

Thanks,

venkat
