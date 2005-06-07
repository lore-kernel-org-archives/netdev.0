From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: RFC: NAPI packet weighting patch
Date: Mon, 06 Jun 2005 21:53:32 -0700
Message-ID: <42A5284C.3060808@osdl.org>
References: <468F3FDA28AA87429AD807992E22D07E0450C00B@orsmsx408> <Pine.CYG.4.58.0506061647340.128@mawilli1-desk2.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Ronciak, John" <john.ronciak@intel.com>,
        "David S. Miller" <davem@davemloft.net>, mchan@broadcom.com,
        hadi@cyberus.ca, buytenh@wantstofly.org, jdmason@us.ibm.com,
        netdev@oss.sgi.com, Robert.Olsson@data.slu.se,
        "Venkatesan, Ganesh" <ganesh.venkatesan@intel.com>,
        "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Mitch Williams <mitch.a.williams@intel.com>
In-Reply-To: <Pine.CYG.4.58.0506061647340.128@mawilli1-desk2.amr.corp.intel.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I noticed that the tg3 driver copies packets less than a certain
threshold to a new buffer, but e1000 always passes the big buffer up
the stack. Could this be having an impact?
