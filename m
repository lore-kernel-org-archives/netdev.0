From: kuznet@ms2.inr.ac.ru
Subject: Re: O/M flags against 2.6.0-test1
Date: Thu, 24 Jul 2003 18:02:35 +0400 (MSD)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200307241402.SAA09143@dub.inr.ac.ru>
References: <20030724000705.4662df54.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: krkumar@us.ibm.com, yoshfuji@linux-ipv6.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com (David S. Miller)
In-Reply-To: <20030724000705.4662df54.davem@redhat.com> from "David S. Miller" at éÀÌ 24, 2003 12:07:05 
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

> Another idea is to define the user structure:

Actually, I saw it just as array indexed by values from sysctl.h.

Maybe, struct is better, but I am inclined to think in this case it is wrong.
It is going to be extended, so newly compiled applications will see
truncated structs from older kernels and will have to do ugly job
verifying validity of fields using some offsetof. In the case of array
it is natural at least.

Alexey

PS I know right way is not to change the struct. :-)
It is another reason why I am still not sure that encoding
sysctl values as separate subattributes is bad idea.
