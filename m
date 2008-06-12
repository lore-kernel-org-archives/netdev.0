From: "Ramachandra K" <ramachandra.kuchimanchi@qlogic.com>
Subject: Re: [ofa-general] Re: [PATCH v4 14/14] QLogic VNIC: sysfs
	Documentation
Date: Thu, 12 Jun 2008 20:59:05 +0530
Message-ID: <71d336490806120829o7cac67bes384c305e03b0d746@mail.gmail.com>
References: <20080610205633.11186.45499.stgit@dale>
	<20080610210918.11186.64253.stgit@dale> <484F751F.7030407@trash.net>
	<c8028d330806120813q6363c3cemb4aa03ceff6547d1@mail.gmail.com>
	<48513E4E.4040601@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rdreier@cisco.com, poornima.kamath@qlogic.com,
	general@lists.openfabrics.org, Amar Mudrankit <amar.mudrankit@qlogic.com>
To: "Patrick McHardy" <kaber@trash.net>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <48513E4E.4040601@trash.net>
Content-Disposition: inline
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 12, 2008 at 8:48 PM, Patrick McHardy <kaber@trash.net> wrote:
> Amar Mudrankit wrote:
>>>>
>>>> +/sys/class/infiniband_qlgc_vnic/interfaces/<VNIC-interface-name>/
>>>> +
>>>> +       vnic_state      (0444)  State of the VNIC interface.
>>>
>>> This I don't understand - you seem to be registering and
>>> unregistering the net_device based some state machine,
>>> in some cases even triggered by timers.
>>>
>>> Whats the idea behind this?
>>
>> For a given VNIC interface, unless the VNIC host driver establishes a
>> connection with EVIC
>> and completes the control and data path communication sequence with
>> the EVIC, the
>> VNIC network device is not registered on the host.  Establishing a
>> connection with EVIC
>> and going through the control and data path communication involves
>> multiple packet
>> exchange on the IB side with the EVIC and can take some time.  The
>> netpath statemachine is, hence, meant to PERIODICALLY check if
>> connection is fully established with EVIC or not.
>> Once connection is established, it takes care to register the VNIC
>> netdevice.
>
>
> We have linkstate/operstate for this. How is a user supposed
> to configure the network device when it appears at a more or
> less random time from his perspective?
>
If you are referring to IP address configuration etc, users can configure
the interfaces by setting up ifcfg files and the interfaces are automatically
configured when they are registered.

Regards,
Ram
