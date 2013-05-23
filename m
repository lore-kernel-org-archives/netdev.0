From: Alex Rosenbaum <alexr@mellanox.com>
Subject: Re: [PATCH v3 net-next 0/4] net: low latency Ethernet
	device polling
Date: Thu, 23 May 2013 14:45:43 +0300
Message-ID: <519E0167.6060408@mellanox.com>
References: <20130520101552.14133.45953.stgit@ladj378.jer.intel.com>
	<519B632F.7040202@mellanox.com> <519B68A4.3010406@linux.intel.com>
	<519B7355.9090303@mellanox.com> <519DF84B.10401@linux.intel.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============7932222427563873125=="
Cc: Willem de Bruijn <willemb@google.com>, Don,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	HPA <hpa@zytor.com>, Jesse Brandeburg <jesse.brandeburg@intel.com>,
	linux-kernel@vger.kernel.org, Andi Kleen <andi@firstfloor.org>,
	Eliezer Tamir <eliezer@tamir.org.il>, Dave Miller <davem@davemloft.net>
To: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <519DF84B.10401@linux.intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

--===============7932222427563873125==
Content-Type: multipart/alternative;
	boundary="------------030502030606020500070500"

--------------030502030606020500070500
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit

On 5/23/2013 2:06 PM, Eliezer Tamir wrote:
> On 21/05/2013 16:15, Alex Rosenbaum wrote:
>> On 5/21/2013 3:29 PM, Eliezer Tamir wrote:
>>> What benchmarks are you using to test poll/select/epoll?
>> for epoll/select latency tests we are using sockperf as performance
>> latency tool: https://code.google.com/p/sockperf/
>> It is a client-server based tool and it supported ping-pong, throughput,
>> and under-load test type.
>> For epoll, you will need to define a 'feedfile' ("-f filepathname")
>> which has a list of TCP and/or UDP socket and defined your IO mux type
>> ("-F epoll").
>
> Thank you!
> This is very helpful.
>
> With sockperf i can directly observe how poll/select/epoll are behaving.
> I can see some improvement in all of them but clearly more work is 
> needed here.
>
> -Eliezer

I'm happy you got it working.

If you add '--timeout=0' to the sockperf epoll command line you can see 
non-blocking epoll application behavior and then you will get some 
improved latency over due to the application thread not sleeping.

This is not like a full blown LLS epoll solution but half way there.


Alex


--------------030502030606020500070500--


--===============7932222427563873125==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

------------------------------------------------------------------------------
Try New Relic Now & We'll Send You this Cool Shirt
New Relic is the only SaaS-based application performance monitoring service 
that delivers powerful full stack analytics. Optimize and monitor your
browser, app, & servers with just a few lines of code. Try New Relic
and get this awesome Nerd Life shirt! http://p.sf.net/sfu/newrelic_d2d_may
--===============7932222427563873125==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired

--===============7932222427563873125==--
