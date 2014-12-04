From: Joe Stringer <joestringer@nicira.com>
Subject: Re: [linux-nics] [PATCHv3 net] i40e: Implement ndo_gso_check()
Date: Thu, 4 Dec 2014 13:12:58 -0800
Message-ID: <CANr6G5zcPEZPWktNK3N2aCHma-o3_o1hvBzGeZ=nYQi5ijTheA@mail.gmail.com>
References: <1417718366-14310-1-git-send-email-joestringer@nicira.com>
 <5480B1F0.9090407@cogentembedded.com> <1417720816.2404.11.camel@jtkirshe-mobl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"linux.nics" <linux.nics@intel.com>,
	Jesse Gross <jesse@nicira.com>,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	Tom Herbert <therbert@google.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1417720816.2404.11.camel@jtkirshe-mobl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>> > +#define MAX_TUNNEL_HDR_LEN 80
>>
>>     I'd #define this just above the function, if not at the start of the file...

Right, the style for most of this file is to place the #define like
this above the function. I'll do that.
