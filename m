From: "Shekhar Kshirsagar" <shekhark@juniper.net>
Subject: RE: ipsec null encryption slower than AES / was Re: 2.6 IPSec Throughput puzzle
Date: Sat, 1 Jan 2005 22:51:13 -0800
Message-ID: <EF311E6F9B0B0848A49ED20B06E9CB270320B02A@gluon.jnpr.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 8bit
Cc: "Networking Team" <netdev@oss.sgi.com>, <jmorris@redhat.com>
Return-path: <netdev-bounce@oss.sgi.com>
Content-class: urn:content-classes:message
To: "bert hubert" <ahu@ds9a.nl>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> From your numbers below it is clear all ipsec benchmarks have maxed out your
> CPU, but aes/sha1 still has some hits in default_idle. Is this an SMP
> system?
No, it is not running SMP kernel. (The system is SMP). 
About little time being sent in default_idle, I think,it was because I was little late in 
performing dump. I redid the test and the CPU was maxed out even in aes/sha1 case.
 
> http://www.certconf.org/presentations/2004/Tuesday/TS2.pdf - the concept is
> called 'the scatterlist'.
> http://lwn.net/Articles/14010/?format=printable is also nice.
Thanks, for the pointers. I will see, if I can isolate the problem. 

Shekhar
