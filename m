From: Bill Crowell <bill@crowellsystems.com>
Subject: Re: Fw: ipsec hang
Date: Mon, 29 Nov 2004 17:17:56 -0500
Message-ID: <41ABA014.4090309@crowellsystems.com>
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

Hi,

I'm trying to test the IPSec, but haven't been able to get the new 
update onto the remote computer due to problems that appear to be based 
on memory management. The bootloader uses tmpfs to build a file system 
and it's dying there.

On the development server, I'm getting such nifty things as:
root@s3:/mfxlinux/Npublish# grep -ri Slackware *
Build_Modules.sh:Base="Slackware"
Build_Modules.sh:               if [ "$Base" = "Slackware" ]; then
Build_Modules.sh:                       Line=${Line/"RedHat"/"Slackware"}
Build_Modules.sh:                       Line=${Line/"Slackware"/"RedHat"}
Initial/etc/Base:Slackware
grep: memory exhausted
root@s3:/mfxlinux/Npublish#

The memory exhausted is not nice. 2GB ram on this server. Runs fine when 
I rev to 2.6.10-rc2. Obviously something else is broken in bk12.

***
Also, Herbert's email system is blocking messages from my zone. If you 
can forward to him, that would be appreciated.

***
Re the bk12, is there just 1 patch that I should install to 2.6.10-rc2 
to test IPSec? If I don't fiddle with the mm code, we might be able to 
make some progress on this part. I just love simultaneous equations with 
1000 or more variables... ;-)

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
