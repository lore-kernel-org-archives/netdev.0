From: "Christopher K. Johnson" <ckjohnson@gwi.net>
Subject: Re: IPsec tunnel mode bug - malformed, misaddressed packets
Date: Mon, 18 Oct 2004 19:17:50 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <41744F1E.9090103@gwi.net>
References: <41725CF5.2010606@gwi.net> <20041018010816.GA30059@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <20041018010816.GA30059@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:

>On Sun, Oct 17, 2004 at 11:52:21AM +0000, Christopher K. Johnson wrote:
>  
>
>>There is an ipsec bug in FC2 kernel 2.6.8-1.521 for ipsec tunnel mode.
>>I have proven with a packet trace that some packets are
>>misaddressed.  Specifically it constructs a packet of the form:
>>IP header1 | AH header | IP header2 | ESP
>>    
>>
>In this case, racoon needs to be taught that only the inner SA
>should be marked as tunnel mode.
>  
>
I updated the vpn peers to ipsec-tools-0.3.3-1 from fedora core 
development and the problem is the same.  I captured a packet trace to 
verify.  Any takers for an ipsec-tools bug?  I'll gladly provide more 
details off-list.

Thanks.
