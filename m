From: Don Fry <brazilnut@us.ibm.com>
Subject: Re: [PATCH] pcnet32 driver NAPI support
Date: Wed, 7 Jun 2006 15:32:45 -0700
Message-ID: <20060607223245.GA13584@us.ibm.com>
References: <20060607165225.GB7859@csclub.uwaterloo.ca> <20060607182040.GA12748@us.ibm.com> <20060607193456.GN7857@csclub.uwaterloo.ca> <20060607215236.GA13380@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:51164 "EHLO
	e33.co.us.ibm.com") by vger.kernel.org with ESMTP id S932444AbWFGWci
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Jun 2006 18:32:38 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e33.co.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k57MWbE5020012
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Wed, 7 Jun 2006 18:32:37 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.6/NCO/VER7.0) with ESMTP id k57MWbI2267778
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Wed, 7 Jun 2006 16:32:37 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k57MWbZY032048
	for <netdev@vger.kernel.org>; Wed, 7 Jun 2006 16:32:37 -0600
To: Lennart Sorensen <lsorense@csclub.uwaterloo.ca>
Content-Disposition: inline
In-Reply-To: <20060607215236.GA13380@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

One other problem I ran into.  I applied the patch but it will not
compile because rl_active is never defined.  I have worked around it but
...


-- 
Don Fry
brazilnut@us.ibm.com
