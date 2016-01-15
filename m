From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: Re: gianfar: Delete unnecessary variable initialisations in
 gfar_ethflow_to_filer_table()
Date: Fri, 15 Jan 2016 18:15:14 +0100
Message-ID: <56992922.4080500@users.sourceforge.net>
References: <5698C61A.90504@users.sourceforge.net>
 <20160115102947.GI4764@mwanda> <5698D949.6000404@users.sourceforge.net>
 <20160115.114253.673366436532953675.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Claudiu Manoil <claudiu.manoil@freescale.com>,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org,
	Julia Lawall <julia.lawall@lip6.fr>
To: David Miller <davem@davemloft.net>,
	Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160115.114253.673366436532953675.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>>> This is a write only variable.  We can just remove it.
>>
>> Can a static source code analysis tool like the software "http://smatch.sourceforge.net/"
>> detect that such a variable is not read by this function implementation so far?
> 
> No,

I imagine that there are a few tools available which can point such update candidates out.
There are various software development challenges to consider.


> but a human can.

Some software developers and source code reviewers are struggling with mentioned
implementation details as usual. Do they also wonder how the discussed variable assignment
was left over in a specific function?


> I am going to be honest, and say that I am completely ignoring most of
> your static checker patches.

I am curious if you would reconsider the affected source code places once more
when you will be notified about related issues by other tools or persons.


> You don't put enough care and consideration into them,

Would you like to explain this impression a bit more?


> and I really don't have time to waste on looking at something like that.

Thanks for your feedback.

Various open issues are competing for our attention as usual.

Regards,
Markus
