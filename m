From: Christian Schmid <webmaster@rapidforum.com>
Subject: Re: Bug-hunting
Date: Tue, 22 Feb 2005 20:17:55 +0100
Message-ID: <421B8563.9030608@rapidforum.com>
References: <421B4AB7.9030003@rapidforum.com> <20050222104448.31373a99.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050222104448.31373a99.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

No. This is a new thing and this wasnt there before. In 2.6.10-rc2 the kernel aborted programs with 
"Out of memory" when too many buffers are allocated and low memory was full. NOW it just shrinks the 
buffers dynamically. I don't want that. I have a 2/2 system and I want 1600 MB for buffers but you 
only allow around 700 MB for buffers. This is definetly NEW.

David S. Miller wrote:
> On Tue, 22 Feb 2005 16:07:35 +0100
> Christian Schmid <webmaster@rapidforum.com> wrote:
> 
> 
>>I am still trying to hunt down the bug with the slowdown-on-many-sockets. Is there any way I can see 
>>how much tcp-memory is used right now? Why did you change the behaviour? In 2.6.10-rc2 I was able to 
>>see the amount by looking in slabinfo but now the buffers are gone. And where did you introduce the 
>>buffer-limit? It seems its now globally limited to xxx MB. I want to disable this in order to check 
>>if thats the reason.
> 
> 
> The global TCP memory limit, controllable by sysctl()'s, has been there for
> at least 3 years.
> 
> 
