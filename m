From: "David S. Miller" <davem@redhat.com>
Subject: Re: SIOCETHTOOL history ?
Date: Tue, 06 May 2003 04:49:26 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030506.044926.132916721.davem@redhat.com>
References: <01f301c313cc$4e6cb8b0$243205c0@otp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: akumar@omnesysindia.com
In-Reply-To: <01f301c313cc$4e6cb8b0$243205c0@otp.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: "arun" <akumar@omnesysindia.com>
   Date: Tue, 6 May 2003 18:07:48 +0530
   
   I have used SIOCGMIIPHY before and it seemed not to require 
   any su rights or capabilities.

Yes it does:

                /*
                 *      These ioctl calls:
                 *      - require superuser power.
                 *      - require strict serialization.
                 *      - return a value
                 */
                case SIOCETHTOOL:
                case SIOCGMIIPHY:
                case SIOCGMIIREG:
                        if (!capable(CAP_NET_ADMIN))
                                return -EPERM;
