From: "Martin J. Bligh" <Martin.Bligh@us.ibm.com>
Subject: Re: Early SPECWeb99 results on 2.5.33 with TSO on e1000
Date: Fri, 06 Sep 2002 07:37:16 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <46676537.1031297834@[10.10.2.3]>
References: <15736.38178.445310.714015@robur.slu.se>
Reply-To: "Martin J. Bligh" <Martin.Bligh@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@zip.com.au, hadi@cyberus.ca, tcw@tempest.prismnet.com,
   linux-kernel@vger.kernel.org, netdev@oss.sgi.com, niv@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Robert Olsson <Robert.Olsson@data.slu.se>,
   "David S. Miller" <davem@redhat.com>
In-Reply-To: <15736.38178.445310.714015@robur.slu.se>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> And NAPI scheme behaves different since we can not assume that all network 
> traffic is well-behaved like TCP. System has to be manageable and to "perform"
> under any network load not only for well-behaved TCP. So of course we will 
> see some differences -- there are no free lunch. Simply we can not blindly
> look at one test. IMO NAPI is the best overall performer. The number speaks 
> for themselves.

I don't doubt it's a win for most cases, we just want to reap the benefit
for the large SMP systems as well ... the fundamental mechanism seems
very scalable to me, we probably just need to do a little tuning?

> NAPI kernel path is included in 2.4.20-pre4 the comparison below is mainly 
> between e1000 driver w and w/o NAPI and the NAPI port to e1000 is still 
> evolving. 

We are running from 2.5.latest ... any updates needed for NAPI for the
driver in the current 2.5 tree, or is that OK?

Thanks,

Martin.
