From: Nivedita Singhvi <niv@us.ibm.com>
Subject: Re: [PATCH] Optimize loopback stats
Date: Tue, 15 Mar 2005 12:49:51 -0800
Message-ID: <42374A6F.50300@us.ibm.com>
References: <200503151459_MC3-1-989A-61A4@compuserve.com> <4237423E.2040505@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-netdev <netdev@oss.sgi.com>, Andrew Morton <akpm@osdl.org>,
        Christoph Lameter <clameter@sgi.com>
To: Chuck Ebbert <76306.1226@compuserve.com>
In-Reply-To: <4237423E.2040505@us.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Nivedita Singhvi wrote:
> Chuck Ebbert wrote:
> 
>>   This patch optimizes the loopback driver's statistics by using a single
>> counter for rx and tx stats instead of one for rx and one for tx.  It 
>> also
>> adds unlikely() to the test for TSO since it's no longer supported by 
>> default.
>> (Maybe the TSO code should be bracketed by "#if 0" ?)
> 
> 
> Hmm, some of us want those counters separate - if this is really
> needed, could it be a configurable option, please?

Or we could live with the appropriate patches to ip, ifconfig,
reporting them separately (halving them). That would be fine.

thanks,
Nivedita
