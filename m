From: Christian Schmid <webmaster@rapidforum.com>
Subject: Re: ARGH MORE BUGS!!!
Date: Mon, 21 Feb 2005 22:17:46 +0100
Message-ID: <421A4FFA.7090003@rapidforum.com>
References: <421A3EB8.4050607@rapidforum.com> <20050221202854.GA26248@electric-eye.fr.zoreil.com> <421A45CA.80001@rapidforum.com> <20050221205606.GB26248@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20050221205606.GB26248@electric-eye.fr.zoreil.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Its attached, since these are several files. your script didnt work. I used this one:

# nice -n -19 vmstat 1 > /tmp/v & nice -n -19 perl -e 'for(1..1000){sleep(1);system("cat 
/proc/slabinfo > /tmp/sl$_")}'

I started it after one break-cyclus and stopped it immedately after the next break-cyclus ended.

Francois Romieu wrote:
> Christian Schmid <webmaster@rapidforum.com> :
> [...]
> 
> Let's calm down, please.
> 
> # cat>/tmp/momo<<EOD
> i=0
> while : ; do
>         cat /proc/slabinfo > /tmp/\$i
>         i=$[ $i + 1 ]
>         sleep 1
> done
> EOD
> # nice -n -19 vmstat 1 > /tmp/v & nice -n -19 sh /tmp/momo
> 
> Wait a few minutes or more until the 5s pauses happen several times
> and post the result somewhere.
> 
> I doubt I'll fix it but it should give nifty graphics.
> 
> --
> Ueimor
> 
> 
