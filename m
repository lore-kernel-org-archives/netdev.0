From: Christian Schmid <webmaster@rapidforum.com>
Subject: Re: ARGH MORE BUGS!!!
Date: Mon, 21 Feb 2005 21:25:34 +0100
Message-ID: <421A43BE.6080604@rapidforum.com>
References: <421A3EB8.4050607@rapidforum.com> <421A4244.9090908@tiscali.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: Matthias-Christian Ott <matthias.christian@tiscali.de>
In-Reply-To: <421A4244.9090908@tiscali.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

netdev@oss.sgi.com has been found in MAINTAINERS in the ipv4/ipv6 section ;)

Matthias-Christian Ott wrote:
> Christian Schmid wrote:
> 
>> Hi.
>>
>> Another bug hit me today HARD! I have been experiencing with lowering 
>> the socket-buffer to see if the behaviour of a slowdown reappears at 
>> the same position. Result: With a 128 KB send-buffer, the slowdown 
>> appears at around 3000 sockets. With 64 KB, it didnt appear up to 4500 
>> sockets where a small slow-down appeared but I think this was a 
>> disk-issue. So its definetly something with TCP-memory.
>>
>> But now I hit another BUG: After I have managed to create 4500 
>> sockets, 10 minutes later an interesting phenomenon appeared: It locks 
>> for 5 seconds every 60 seconds. I first thought this was something in 
>> my program but I can do what I want, I wasn't able to fix this. Even a 
>> restart of my program didnt help. It even appears with 400 
>> connections. Then I despairedly just restarted the system and: It was 
>> gone. So what is THIS?
>>
>> Sorry if I am a bit angry. I know you are doing a really good job. 
>> Maybe I can donate some money somewhere but PLEASE!!!!! help me fix 
>> this bugs.... Thank you.
>>
>> Chris
>>
>>
> Hi!
> I'm not a Perl Coder or Socket Specialist, but did try an implementation 
> of your program in C (maybe it's a perl "bug"?)? And as mentioned in the 
> other Thread, try to use send () instead of sendfile (). Anyway it's 
> strange. Try to contact some of the Maintainers and Developers of this 
> part of the IP v4 implementation in Linux.
> 
> Matthias-Christian Ott
> 
> 
