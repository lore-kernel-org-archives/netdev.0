From: Ben Greear <greearb@candelatech.com>
Subject: RFC:  Enabling ethernet drivers to return FCS in the skb?
Date: Mon, 17 Nov 2003 13:52:17 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3FB94311.10004@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Ethereal now has the ability to decode (and check) the FCS for ethernet
frames (assuming it understands the protocol so it can determine that the last
4 bytes are FCS).

Is there any interest in adding an Ethtool command to tell the driver to
push the extra 4 bytes of CSUM into the skb?

When enabling this feature, I'd also like to allow drivers to receive
frames with bad FCS as well.  This could be a separate flag if desired,
but if only good FCS will ever be passed up the stack, then having it in
the skb does not really add new information.  At least some hardware appears
to support receiving bad FCS frames (e1000, evidently), but I am not sure
how wide-spread this feature is...

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
