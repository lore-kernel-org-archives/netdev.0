From: Roland Dreier <rdreier@cisco.com>
Subject: Re: MediaGX/GeodeGX1 requires X86_OOSTORE.
Date: Mon, 19 Feb 2007 11:48:27 -0800
Message-ID: <ada3b5253p0.fsf@cisco.com>
References: <20070216222728.GF7585@csclub.uwaterloo.ca>
	<20070216224824.GG7585@csclub.uwaterloo.ca>
	<20070217000019.GH7582@csclub.uwaterloo.ca>
	<20070217.231113.193678444.takada@mbf.nifty.com>
	<20070219145514.GO7582@csclub.uwaterloo.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: takada <takada@mbf.nifty.com>, pcnet32@verizon.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: lsorense@csclub.uwaterloo.ca (Lennart Sorensen)
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-5.cisco.com ([171.68.10.87]:39032 "EHLO
	sj-iport-5.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932514AbXBSTsa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Feb 2007 14:48:30 -0500
In-Reply-To: <20070219145514.GO7582@csclub.uwaterloo.ca> (Lennart Sorensen's message of "Mon, 19 Feb 2007 09:55:14 -0500")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 > Does anyone know if there is any way to flush a cache line of the cpu to
 > force rereading system memory for a given address or address range?

There is the "clflush" instruction, but not all x86 CPUs support it.
You need to check the CPUID flag to know for sure (/proc/cpuinfo will
show a "clflush" flag if it is supported).
