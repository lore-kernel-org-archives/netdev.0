From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [patch net-next] cxgb3: update firmware version
Date: Tue, 14 Feb 2012 12:02:26 -0800
Message-ID: <4F3ABDD2.4000207@hp.com>
References: <20120213202846.631.30806.stgit@speedy5.asicdesigners.com> <1329165817.2092.62.camel@shinybook.infradead.org> <4F398303.1030606@chelsio.com> <1329184754.3048.33.camel@deadeye> <4F39E7C9.20901@chelsio.com> <1329196116.3048.66.camel@deadeye> <4F39F75D.6030107@chelsio.com> <4F3AA537.4050700@hp.com> <20120214182110.GO12704@decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Divy Le Ray <divy@chelsio.com>,
	David Woodhouse <dwmw2@infradead.org>, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Steve Wise <swise@opengridcomputing.com>, nhorman@tuxdriver.com
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120214182110.GO12704@decadent.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/14/2012 10:21 AM, Ben Hutchings wrote:
> On Tue, Feb 14, 2012 at 10:17:27AM -0800, Rick Jones wrote:
>> What does an end-user/customer see and do?  When they are told that
>> version the firmware, specified down to the fix level, fixes a
>> problem they are having, how will they know that firmware blob
>> filename drvfw-X.bin on a download/archive site has that fix?
> [...]
>
> Customers currently can't get bug fixes by updating the firmware.
> Think about it.

Because in this case at least the driver is requesting a specific 
filename down to the minor and micro level and a change in the filename 
requires a change in the driver?

#define FW_VERSION __stringify(FW_VERSION_MAJOR) "."                    \
         __stringify(FW_VERSION_MINOR) "." __stringify(FW_VERSION_MICRO)
#define FW_FNAME "cxgb3/t3fw-" FW_VERSION ".bin"

rather than the driver having logic to make it willing to accept later 
minor/micro changes by being more sophisticated in its specification of 
firmware file.
