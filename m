From: Christian Schmid <webmaster@rapidforum.com>
Subject: How to remove TCP-limits?
Date: Sat, 29 Jan 2005 17:06:53 +0100
Message-ID: <41FBB49D.2020809@rapidforum.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Referring to the following:

 >In 2.6.10 there has been a "bug" introduced. You may also call it a feature, but its a crappy 
 >feature for big servers. It seems the kernel is dynamically adjusting the buffer-space available 
 >for sockets. Even if send-buffer has been set to 1024 KB, the kernel blocks at less if there are 
 >enough sockets in use. If you have 10 sockets with 1024 KB each, they do not block at all, using 
 >full 1024 KB. If you have 4000 sockets, they only use 200 KB. So it seems its blocking at 800 MB. 
 >This is good, if you have a 1/3 system, because else the kernel would run out of low mem. But I 
 >have a 2/2 system and I need them for buffers. So what can I do? Where can I adjust the "pool"?

How can I disable this? I have been searching the code but I can't find it. Or can I at least adjust 
it somehow? Thank you in advance.

Best regards,
Christian Schmid - RapidTec
