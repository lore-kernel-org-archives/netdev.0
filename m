From: Kazunori Miyazawa <kazunori@miyazawa.org>
Subject: Re: IPSec: 2.5.68 test results
Date: Fri, 25 Apr 2003 10:10:12 +0900
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030425101012.05e172bb.kazunori@miyazawa.org>
References: <1051219792.5206.52.camel@tomlt2.tomloffice.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, davem@redhat.com, kuznet@ms2.inr.ac.ru,
   toml@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Tom Lendacky <toml@us.ibm.com>
In-Reply-To: <1051219792.5206.52.camel@tomlt2.tomloffice.austin.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 24 Apr 2003 16:29:51 -0500
Tom Lendacky <toml@us.ibm.com> wrote:

> The four test cases that fail for the ipsec test are related to
> fragment header processing and will need to be debugged and fixed.

I have already posted the patch to netdev on 15, April,
whose subject is [PACTH][IPV6] Introduce ip6_append_data.
It change the style of the process like ip_append_data and
fixes outbound fragment header processing.

However this patch will not be applied soon because there is locking problem.
The bugs is in both ipv4 and ipv6 corking architecture of datagram output.
It may be applied when the bugs is removed.

About inbound processing, we can fix it with removing fragment header from the packet.
Please see function ip6_frag_reasm in  linux25/net/ipv6/reassembly.c.

Thank you,

--Kazunori Miyazawa (Yokogawa Electric Corporation)
