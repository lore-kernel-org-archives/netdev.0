From: James Ketrenos <jketreno@linux.jf.intel.com>
Subject: wireless management... kernel or user space?
Date: Thu, 17 Jun 2004 15:47:47 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40D20373.3020406@linux.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


With the various discussions going on about a generic 802.11 frame/management 
stack, and the recent thread on wireless extensions, I wanted to find out what 
people's thoughts are on where wireless management should occur -- kernel or 
user space...

Within the hostap project there exists the ability to have some AP management 
occur internal to the driver or (via the PRISM2_NO_KERNEL_IEEE80211_MGMT define) 
in a user space daemon.

Does anyone have any thoughts on how much logic should be placed into the 
generic 802.11 frame/management/control handling stack vs. pushing to a user 
space component?

If (for example) AP associate request / response policy is pushed to a user 
space component, by what mechanism does it make sense for the driver/application 
to send/receive the 802.11 frames?  Are people happy with the way Host AP 
currently does it, or is there a better way?

Other types of policy that could occur in user space would be for scan requests, 
probe response collection, AP selection to associate, etc.  What is the general 
direction the wireless networking stack should take?  Minimize kernel side 
wherever possible?

With ipw2100 (and I believe other cards) the hw/fw handles a lot of the above 
internally, so the mechanism by which the user space application communicates 
with the driver would need allow for hw/fw capabilities to be exposed so the 
user doesn't get a broken experience.

Thoughts?

James
(of ipw2100.sf.net)
