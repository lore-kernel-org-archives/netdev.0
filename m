From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH 00/39] merge request for WiMAX kernel stack and i2400m
	driver v2
Date: Thu, 27 Nov 2008 11:41:13 +0100
Message-ID: <8A11A72D-4557-4FAF-98C0-72C09F8E18B2@holtmann.org>
References: <cover.1227691434.git.inaky@linux.intel.com>
	<200811271118.32110.a.miskiewicz@gmail.com>
Mime-Version: 1.0 (Apple Message framework v929.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, wimax@linuxwimax.org
To: Arkadiusz Miskiewicz <a.miskiewicz@gmail.com>
Return-path: <wimax-bounces@linuxwimax.org>
In-Reply-To: <200811271118.32110.a.miskiewicz@gmail.com>
List-Unsubscribe: <http://www.linuxwimax.org/mailman/listinfo/wimax>,
	<mailto:wimax-request@linuxwimax.org?subject=unsubscribe>
List-Archive: <http://lists.moblin.org/pipermail/wimax>
List-Post: <mailto:wimax@linuxwimax.org>
List-Help: <mailto:wimax-request@linuxwimax.org?subject=help>
List-Subscribe: <http://www.linuxwimax.org/mailman/listinfo/wimax>,
	<mailto:wimax-request@linuxwimax.org?subject=subscribe>
Sender: wimax-bounces@linuxwimax.org
Errors-To: wimax-bounces@linuxwimax.org
List-Id: netdev.vger.kernel.org

Hi Arkadiusz,

>> driver for the Intel 2400m Wireless WiMAX
>> connection to the tree. We'd like to get it in for the 2.6.29 merge
>> window.
>
> Is 802.11b/g also supported by this driver (or other existing linux  
> driver) ?
>
> AFAIK these intel cards do support 802.11b/g, too.

some of them are multi-function devices and Linux binds drivers on a  
per function (or in the USB term, interface). So in case of multi- 
radio cards you need separate drivers for each function. The 2400m  
driver is only responsible for the WiMAX function.

Regards

Marcel
