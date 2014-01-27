From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 3/3] net: ethoc: document OF bindings
Date: Mon, 27 Jan 2014 18:21:51 +0400
Message-ID: <52E66B7F.3010209@cogentembedded.com>
References: <1390795167-6677-1-git-send-email-jcmvbkbc@gmail.com>	<1390795167-6677-4-git-send-email-jcmvbkbc@gmail.com> <CAL_JsqLjn4FXrNGLGHs639TEqmQKPx_kk9JbAd-hn7mexzAjNg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-xtensa@linux-xtensa.org, netdev <netdev@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Chris Zankel <chris@zankel.net>,
	Marc Gauthier <marc@cadence.com>,
	"David S. Miller" <davem@davemloft.net>,
	Grant Likely <grant.likely@linaro.org>,
	Rob Herring <rob.herring@calxeda.com>
To: Rob Herring <robherring2@gmail.com>,
	Max Filippov <jcmvbkbc@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAL_JsqLjn4FXrNGLGHs639TEqmQKPx_kk9JbAd-hn7mexzAjNg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 27-01-2014 18:10, Rob Herring wrote:

>> Signed-off-by: Max Filippov <jcmvbkbc@gmail.com>
>> ---
>>   .../devicetree/bindings/net/opencores-ethoc.txt    | 25 ++++++++++++++++++++++
>>   1 file changed, 25 insertions(+)
>>   create mode 100644 Documentation/devicetree/bindings/net/opencores-ethoc.txt

>> diff --git a/Documentation/devicetree/bindings/net/opencores-ethoc.txt b/Documentation/devicetree/bindings/net/opencores-ethoc.txt
>> new file mode 100644
>> index 0000000..f7c6c94
>> --- /dev/null
>> +++ b/Documentation/devicetree/bindings/net/opencores-ethoc.txt
>> @@ -0,0 +1,25 @@
[...]

>> +- reg: Address and length of the register set for the device and of its
>> +  descriptor memory.
>> +- interrupts: Should contain ethoc interrupt.
>> +
>> +Optional properties:
>> +- local-mac-address: 6 bytes, mac address

> There's a patch in progress to move all the standard network
> properties to a common location, so you can remove this.

    Haven't you asked me to replace the descriptions of common Ethernet props 
with the references to the common bindings file? I'd prefer this prop to 
remain on its place in this case, just the description replaced. 
Unfortunately, my patch will now have to wait till 3.15 (I guess), the same as 
these ones.

WBR, Sergei
