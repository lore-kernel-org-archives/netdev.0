From: Christian Schmid <webmaster@rapidforum.com>
Subject: Bug-hunting
Date: Tue, 22 Feb 2005 16:07:35 +0100
Message-ID: <421B4AB7.9030003@rapidforum.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello.

I am still trying to hunt down the bug with the slowdown-on-many-sockets. Is there any way I can see 
how much tcp-memory is used right now? Why did you change the behaviour? In 2.6.10-rc2 I was able to 
see the amount by looking in slabinfo but now the buffers are gone. And where did you introduce the 
buffer-limit? It seems its now globally limited to xxx MB. I want to disable this in order to check 
if thats the reason.

Chris
