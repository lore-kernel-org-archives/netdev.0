From: "Alexander Zapatka" <alexzapatka@hotmail.com>
Subject: suggested forcedeth updates....
Date: Mon, 17 Nov 2003 23:07:15 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <BAY2-F101QTmReozTIA0001027c@hotmail.com>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

first let me say that forcedeth is a great project!!! i have been using it 
since you have released it and it is awesome....

but about the debuging thing having to change 1 to 0 and recompile is not 
always the easiest thing... so what i did was change the code to look like 
this:

static int debug = 0;
MODULE_PARM(debug,"i");
#if debug
#define dprintk			printk
#else
#define dprintk(x...)		do { } while (0)
#endif

that way you can modprobe/insmod with debug=1 and debuging works... or you 
can just load it, or load it with debug=0 and no debuging info is printed.

just thought it might be a nice addition.
      -o)
      /\\    Message void if penguin violated
     _\_V    Don't mess with the penguin

_________________________________________________________________
Send a QuickGreet with MSN Messenger 
http://www.msnmessenger-download.com/tracking/cdp_games
