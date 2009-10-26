From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH next-next-2.6] netdev: better dev_name_hash
Date: Mon, 26 Oct 2009 09:55:16 -0700
Message-ID: <20091026095516.02f1cb49@nehalam>
References: <200910252158.53921.opurdila@ixiacom.com>
	<200910261631.44666.opurdila@ixiacom.com>
	<4AE5B84E.8040505@gmail.com>
	<200910261752.51784.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Krishna Kumar2 <krkumar2@in.ibm.com>,
	Hagen Paul Pfeifer <hagen@jauu.net>, netdev@vger.kernel.org
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:45826 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751370AbZJZQzS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Oct 2009 12:55:18 -0400
In-Reply-To: <200910261752.51784.opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Added more algorithms to test...

Time is in seconds for 10000000 entries with hashbits = 8
Ratio is number of probes / ideal hash probes

Result sorted by distribution:

Algorithm             Time       Ratio       Max   StdDev
string10             1.434087       1.00     39064   0.01
SuperFastHash        1.469511       1.00     40497   2.17
string_hash17        1.472544       1.00     39497   1.50
jhash_string         1.501508       1.00     39669   1.04
crc                  2.826795       1.00     39088   0.07
md5_string           3.608253       1.00     39605   0.98
djb2                 1.462722       1.15     60681  76.16
string_hash31        1.457253       1.21     64950  91.12
sdbm                 1.566174       2.38    129900 232.22
pjw                  1.527306       2.45     99990 237.86
elf                  1.576096       2.45     99990 237.86
kr_hash              1.400072       7.80    468451 515.52
fletcher             1.449671       7.80    468451 515.52
full_name_hash       1.487707      13.09    562501 687.24
xor                  1.400403      13.36    583189 694.98
lastchar             1.348798      25.60   1000000 980.27

Another run sorted by speed:
Algorithm             Time       Ratio       Max   StdDev
lastchar             1.338545      25.60   1000000 980.27
kr_hash              1.398453       7.80    468451 515.52
xor                  1.398843      13.36    583189 694.98
string10             1.432756       1.00     39064   0.01
fletcher             1.448499       7.80    468451 515.52
string_hash31        1.457524       1.21     64950  91.12
string_hash17        1.462548       1.00     39497   1.50
djb2                 1.462956       1.15     60681  76.16
SuperFastHash        1.469907       1.00     40497   2.17
full_name_hash       1.486465      13.09    562501 687.24
jhash_string         1.500959       1.00     39669   1.04
pjw                  1.526097       2.45     99990 237.86
sdbm                 1.566533       2.38    129900 232.22
elf                  1.576470       2.45     99990 237.86
crc                  2.811210       1.00     39088   0.07
md5_string           3.604675       1.00     39605   0.98

