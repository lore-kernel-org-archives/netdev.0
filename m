From: jamal <hadi@cyberus.ca>
Subject: Re: RFC: NAPI packet weighting patch
Date: Fri, 03 Jun 2005 16:23:25 -0400
Message-ID: <1117830205.6071.81.camel@localhost.localdomain>
References: <1117765954.6095.49.camel@localhost.localdomain>
	 <Pine.CYG.4.58.0506030929300.2788@mawilli1-desk2.amr.corp.intel.com>
	 <1117824150.6071.34.camel@localhost.localdomain>
	 <20050603.120126.41874584.davem@davemloft.net>
	 <1117827650.6071.59.camel@localhost.localdomain>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: mitch.a.williams@intel.com, john.ronciak@intel.com, jdmason@us.ibm.com,
        shemminger@osdl.org, netdev@oss.sgi.com, Robert.Olsson@data.slu.se,
        ganesh.venkatesan@intel.com, jesse.brandeburg@intel.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <1117827650.6071.59.camel@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2005-03-06 at 15:40 -0400, jamal wrote:
> On Fri, 2005-03-06 at 12:01 -0700, David S. Miller wrote:

> 
> I think you are more than likely right. If we can instrument it Mitch
> could check it out. Mitch would you like to try something that will
> instrument this? I know i have seen this behavior but it was when i was
> playing with some system that had a real small HZ.
> 

Sorry, Its already there as Dave said in his email.
Look for time_squeeze. Its the column i labeled XXXX below.

-----
$ cat /proc/net/softnet_stat
0000f938 00000000 XXXXXXX 00000000 00000000 00000000 00000000 00000000
00000000
------

cheers,
jamal
