From: Antonio Dolcetta <zagarna@yahoo.com>
Subject: b44 module problems
Date: Mon, 28 Jul 2003 11:43:02 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030728114302.1cbb6f70.zagarna@yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: pp@ee.oulu.fi
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi, I'm having problems with the new b44 module on linux-2.6-test1 patched
with the same patch that evenually got into test-2

this is how i can reproduce the problem:

1 ) boot and load the module, don't plug in the ethernet cable
2 ) try to configure the card via dhcp, it times out
3 ) rmmod b44

at this point I get cpu at 90% 
new istances of lsmod and rmmod hang during execution
i get the following kernel events:

unregister_netdevice: waiting for eth0 to become free. Usage count = 1

every few seconds, 
is there any more testing i can do for you?

the module works flawlessly otherwise
thank you

	Antonio Dolcetta

-- 
Speaking just for me, I don't think I have Linux blinders on my eyes.
I can see other platforms, but I *choose* to ignore them on the theory
that if I ignore them hard enough they will go away.
This theory is obviously crazy. However, it also appears to be working.
                -- Eric S. Raymond
