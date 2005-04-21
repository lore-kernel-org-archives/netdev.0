From: Scott Feldman <sfeldma@pobox.com>
Subject: Re: [PATCH net-drivers-2.6 5/6] e100: Performance optimizations to e100 Tx Path
Date: Thu, 21 Apr 2005 12:17:56 -0700
Message-ID: <70101da07ff38bf0de89894e91987702@pobox.com>
References: <C925F8B43D79CC49ACD0601FB68FF50C03B1A474@orsmsx408>
Mime-Version: 1.0 (Apple Message framework v622)
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Chilakala, Mallikarjuna" <mallikarjuna.chilakala@intel.com>,
        "Venkatesan, Ganesh" <ganesh.venkatesan@intel.com>,
        <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <C925F8B43D79CC49ACD0601FB68FF50C03B1A474@orsmsx408>
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


On Apr 21, 2005, at 11:59 AM, Brandeburg, Jesse wrote:

>> Where is this 256us delay coming from?
>
> Turning off the 'I' bit allows the transmit interrupt moderation to 
> come
> on, and setting the cid (which was already set) to all 1's indicates 
> the
> max delay (256 us)

This makes sense.  I forgot about the cid delay.  I was afraid the "CPU 
Saver" microcode was coming back.  Thanks Jesse.

-scott
