From: Christian Schmid <webmaster@rapidforum.com>
Subject: Massvie problems with 3000 sockets
Date: Sun, 20 Feb 2005 21:53:44 +0100
Message-ID: <4218F8D8.3040605@rapidforum.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello.

I have a strange problem with 2.6.10 with many many downloaders. Sockets are set to be non-blocking 
of course. Its running fine until it needs more than around 3300 sockets (system-wide) then it 
suddenly blocks on a syswrite although its a non-blocking socket. It blocks only around 100 ms but 
with 3000 sockets its really a pain. Outgoing-traffic breaks down to 50% with 4000 sockets. I have 
limited the sockets to 3000 now since it doesn't happen then. Whats wrong there???

As said, it definetly blocks on a syswrite on a non-blocking socket.

Best regards,
Chris
