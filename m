From: Bill Crowell <bill@crowellsystems.com>
Subject: Re: Fw: ipsec hang
Date: Mon, 29 Nov 2004 09:16:29 -0500
Message-ID: <41AB2F3D.5060903@crowellsystems.com>
References: <E1CXGlt-00069n-00@gondolin.me.apana.org.au> <41A5D1CF.10504@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        James Morris <jmorris@redhat.com>, akpm@osdl.org, netdev@oss.sgi.com,
        mg@iceni.pl
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <41A5D1CF.10504@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I will attempt to load the patch today and rerun the test. It is very 
reproduceable. I've been trying to read the diff view on kernel.org to 
see about any updates, but the server keeps giving me nasty messages: 
internal server error, too many users, etc. I prefer to read the diff 
before patching from bk to see if anything else is impacted.

We'll give it a go this afternoon. As a backup, I've successfully 
installed and tested OpenVPN, though it doesn't provide connectivity to 
other systems (read Cisco) running IPSec.

I'll keep all informed as to the progress.

Thanks for the quick response! I sent a bug report to Redmond about 7 
years ago and am still awaiting a reply ;-)

Bill

Patrick McHardy wrote:

> Herbert Xu wrote:
>
>> James Morris <jmorris@redhat.com> wrote:
>>  
>>
>>> I wonder if it's the same bug as 
>>> http://bugme.osdl.org/show_bug.cgi?id=3796
>>>   
>>
>>
>> Quite likely.
>>
>> Bill, can you please try the latest BK tree and see if you can
>> still reproduce the hang?
>>  
>>
> The patch is not in Linus's tree yet, so you need to apply it
> yourself.
>
> Regards
> Patrick
>
>
>

-- 
William G. Crowell, VP & CTO            | Phone    704.665.2000
Crowell Systems                         | Fax      704.665.2180
4235 South Stream Blvd Suite 100        | NOC      704.357.1885
Charlotte  NC 28217  USA

Computers are like airconditioners: They stop working properly if you open Windows.
