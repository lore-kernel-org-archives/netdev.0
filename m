From: "David S. Miller" <davem@redhat.com>
Subject: Re: Route cache performance under stress
Date: Tue, 20 May 2003 17:13:58 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030520.171358.28794219.davem@redhat.com>
References: <20030520011053.GB10419@netnation.com>
	<20030519.181405.35017608.davem@redhat.com>
	<20030521000936.GA19077@netnation.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hadi@shell.cyberus.ca, netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: sim@netnation.com
In-Reply-To: <20030521000936.GA19077@netnation.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Simon Kirby <sim@netnation.com>
   Date: Tue, 20 May 2003 17:09:36 -0700
   
   It's rather difficult to follow, but I don't see any "h4r h4r, expl0it
   th3 L1nux h4sh" comments or anything in the code that seems to attempt to
   exploit the hash algorithms in (older) Linux.

Look at the vc[] table and how it uses this in rndip().
